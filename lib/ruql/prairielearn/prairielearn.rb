module Ruql
  class PrairieLearn
    require 'builder'
    require 'erb'
    require 'securerandom'      # for uuid generation
    
    attr_reader :output

    def initialize(quiz,options={})
      @quiz = quiz
      @subdirs = []             # since need unique subdir names
      @output = ''
      @default_topic = options.delete('--default-topic') or
                       raise Ruql::OptionsError.new("--default-topic must be specified")
      @omit_tags = options.delete('--omit-tags').to_s.split(',')
      @extra_tags = options.delete('--extra-tags').to_s.split(',')
    end

    def self.allowed_options
      opts = [
        ['--default-topic', GetoptLong::REQUIRED_ARGUMENT],
        ['--omit-tags', GetoptLong::REQUIRED_ARGUMENT],
        ['--extra-tags',  GetoptLong::REQUIRED_ARGUMENT]
      ]
      help = <<eos
The PrairieLearn renderer supports these options:
  --default-topic=TopicName
      REQUIRED: value of "topic" attribute for info.json for questions lacking
      a tag of the form 'topic:TopicName'
  --extra-tags=tag1,tag2
      These tags will be added to all questions' tag lists.
  --omit-tags=tag1,tag2
      Any RuQL questions having tags matching these will be skipped.
A RuQL question's first tag will be used as the question's "title" attribute and subdirectory
name (properly escaped).  If no tags, uuid's will be used for these purposes.
eos
      return [help, opts]
    end

    def render_quiz
      @quiz.questions.each do |q|
        tags = q.question_tags
        if @omit_tags.any? { |t| tags.include? t }
          STDERR.puts %Q{Skipping: #{q.question_text.strip[0,40] + '...'}}
          next
        end
        topic = (t = tags.any? { |tag| tag =~ /^topic:/ }) ?
                  tags.delete(t).gsub(/^topic:/, '') :
                  @default_topic
        title = tags.empty? ? SecureRandom.uuid : tags.first.capitalize
        tags += @extra_tags
        @output << "#{title} // #{topic} // #{tags.join ','}\n"
      end
      self
    end
  end
end
