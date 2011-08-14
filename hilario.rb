require "rbtagger"
require "test/unit"

class HilarioTest < Test::Unit::TestCase  
  
  def initialize(test_case_klass)
    super
    @h = Hilario.new
  end
  
  def test_should_allow_empty_sentence
    assert @h.translate("") == ""
  end
  
  def test_should_not_allow_more_than_120_characters_in_sentence
    long_string = "a" * 121
    
    assert_raise Hilario::SentenceLengthException do
      @h.translate long_string
    end
  end
  
  def test_should_place_adjective_in_front_of_first_noun
    sentence = "i am eating breakfast"
    expected_result = "#{Hilario::REPLACE_ADJECTIVE} i am eating breakfast"
    assert @h.translate(sentence) == expected_result
  end
end

class Hilario
  class SentenceLengthException < Exception
  end
  
  def initialize
    @tagger = Brill::Tagger.new
  end
  
  CLASSIFICATIONS = {
    "CC" => "conjunction",
    "CD" => nil,
    "DT" => nil,
    "EX" => nil,
    "FW" => nil,
    "IN" => "preposition",
    "JJ" => "adjective",
    "JJR" => "adjective",
    "JJS" => "adjective",
    "LS" => nil,
    "MD" => nil,
    "NN" => "noun",
    "NNS" => 'noun-plural',
    "NNP" => 'proper-noun',
    "NNPS" => 'proper-noun-plural',
    "PDT" => nil,
    "POS" => nil,
    "PRP" => "pronoun",
    'PRP$' => 'noun-possessive',
    "RB" => "adverb",
    "RBR" => "adverb",
    "RBS" => "adverb",
    "RP" => "article",
    "SYM" => nil,
    "TO" => nil,
    "UH" => "interjection",
    "VB" => "verb",
    "VBD" => "verb",
    "VBG" => "verb",
    "VBN" => 'past-participle',
    "VBP" => nil,
    "VBZ" => nil,
    "WDT" => nil,
    "WP" => nil,
    'WP$' => nil,
    "WRB" => nil
  }
  
  REPLACE_ADJECTIVE = "beltless"
  REPLACE_ADVERB = "archeologically"
  
  def translate(sentence)
    raise SentenceLengthException if sentence.length > 120
    return "" if sentence.empty?
    
    parsed_sentence = @tagger.tag(sentence)
    parsed_sentence.each_index {|idx| parsed_sentence << idx}
    
    first_noun = find_first_noun(parsed_sentence)
    
    parsed_sentence.insert(first_noun[2]-1, [REPLACE_ADJECTIVE])
    
    parsed_sentence.map{|word| word.first}.join(" ")
  end
  
  private
    def find_first_noun(parsed_sentence)
      parsed_sentence.select{|word| word[1] == CLASSIFICATIONS.select{|k,v| value == "noun"}.first.keys.first}
    end
  
end