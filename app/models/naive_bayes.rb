class NaiveBayes
  include Treat::Core::DSL

  THRESHOLD = 1.5

  def initialize(namespace, *categories)
    @properties = Properties.new(namespace)
    categories.each do |category|
      unless @properties.categories.include? category
        @properties.add_category category
      end
    end
  end

  def ready_to_classify?
    @properties.total_words.present?
  end

  def train(category, document)
    # Process text
    words = extract_words(document) do |word, count|
      # Increment word counts for each category { 'category': { 'word': 1} }
      @properties.incr_category_word(category, word, count)

      # Increment total counts for each category { 'category': 1 }
      @properties.incr_category_word_count(category, count)
    end

    # Increment document count for each category
    @properties.incr_category_document(category)

    # Increment total word count
    @properties.incr_total_words(words.count)

    # Increment total document count
    @properties.incr_total_documents
  end

  def classify(document, default='unknown')
    sorted = probabilities(document).reject{|key,val| val.nan?}.sort {|a,b| a[1]<=>b[1]}
    best,second_best = sorted.pop, sorted.pop
    return best if second_best.nil? || second_best[1].nil?
    return best if best[1]/second_best[1] > THRESHOLD
    return { default => nil }
  end

  private

  def extract_words(document, &block)
    # Remove urls from document. urls confuse the parser.
    document = document.split(' ').reject { |word| word =~ /\A#{URI::regexp(['http', 'https'])}\z/ }.join(' ')
    sect = section document
    sect.do :chunk, :segment, :tokenize, :parse, :category
    words = ['verbs', 'nouns', 'adjectives'].map do |tag|
      sect.send(tag).map(&:value).select(&:present?).map(&:downcase).map(&:stem)
    end.flatten!
    words.uniq.tap do |uniq_words|
      word_count = uniq_words.inject(Hash.new(0)) do |hash_sum, word|
        words.each { |n| hash_sum[word] += 1 if n == word}
        hash_sum
      end
      word_count.each { |word, count| yield(word, count) } if block_given?
    end
  end

  def probabilities(document)
    @properties.categories.inject(Hash.new) do |probabilities, category|
      if @properties.category_word_count(category).present?
        probabilities.tap { |prob| prob[category] = probability(category, document) }
      else
        probabilities
      end
    end
  end

  def probability(category, document)
    doc_probability(category, document) * category_probability(category)
  end

  def doc_probability(category, document)
    extract_words(document).inject(1) { |doc_prob, word| doc_prob *= word_probability(category, word); doc_prob }
  end

  def word_probability(category, word)
    # Apply Lapace smoothing to eliminate zeros
    (@properties.get_category_word(category, word).to_f + 1) / (@properties.category_word_count(category).to_f + @properties.vocab_count.to_f)
  end

  def category_probability(category)
    @properties.category_document(category).to_f / @properties.total_documents.to_f
  end

  class Properties
    def initialize(namespace)
      @namespace = namespace
    end

    def categories
      redis.lrange("#{@namespace}:categories", 0, redis.llen("#{@namespace}:categories"))
    end

    def add_category(category)
      redis.rpush("#{@namespace}:categories", category)
    end

    # Word counts for each category
    def get_category_words(category)
      redis.hgetall("#{@namespace}:category_words:#{category}")
    end

    def get_category_word(category, word)
      redis.hget("#{@namespace}:category_words:#{category}", word)
    end

    def incr_category_word(category, word, count)
      redis.hincrby("#{@namespace}:category_words:#{category}", word, count)
    end

    def total_words
      redis.get("#{@namespace}:total_words")
    end

    def incr_total_words(count)
      redis.incrby("#{@namespace}:total_words", count)
    end

    # Number of documents for each category
    def all_category_documents
      redis.hgetall("#{@namespace}:category_documents")
    end

    def category_document(category)
      redis.hget("#{@namespace}:category_documents", category)
    end

    def incr_category_document(category)
      redis.hincrby("#{@namespace}:category_documents", category, 1)
    end

    def total_documents
      redis.get("#{@namespace}:total_documents")
    end

    def incr_total_documents
      redis.incr("#{@namespace}:total_documents")
    end

    # Number of words in each category
    def category_word_count(category)
      redis.get("#{@namespace}:category_word_counts:#{category}")
    end

    def vocab_count
      categories.map do |category|
        get_category_words(category).keys
      end.flatten.uniq.count
    end

    def incr_category_word_count(category, count)
      redis.incrby("#{@namespace}:category_word_counts:#{category}", count)
    end

    private

    def redis
      @redis ||= Redis.new
    end
  end
end
