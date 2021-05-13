module Ruql
  class Prairielearn
    require 'builder'
    
    attr_reader :output

    def initialize(quiz,options={})
      @quiz = quiz
      @subdirs = []             # since need unique subdir names
      @output = ''
      @default_topic = options.delete('--default-topic') or
        raise Ruql::OptionsError.new("--default-topic must be specified")
      @omit_tags = options.delete('--omit-tags').to_s.split(',')
      @extra_tags = options.delete('--extra-tags').to_s.split(',')
      if (@partial_credit = options.delete('--partial-credit'))
        raise Ruql::OptionsError.new('--partial-credit must be one of EDC or PC if given') unless
          %w(edc pc).include?(@partial_credit.downcase)
      end
    end

    def self.allowed_options
      opts = [
        ['--default-topic', GetoptLong::REQUIRED_ARGUMENT],
        ['--omit-tags', GetoptLong::REQUIRED_ARGUMENT],
        ['--extra-tags',  GetoptLong::REQUIRED_ARGUMENT],
        ['--partial-credit', GetoptLong::REQUIRED_ARGUMENT]
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
  --partial-credit={EDC|PC}
      Grading method for "select all that apply" questions.  If omitted, default is
      no partial credit ("all or nothing").  See documentation at
      https://prairielearn.readthedocs.io/en/latest/elements/#pl-checkbox-element
A RuQL question's first tag will be used as the question's "title" attribute and subdirectory
name (properly escaped).  If no tags, uuid's will be used for these purposes.
eos
      return [help, opts]
    end

    def render_quiz
      begin
        questions_path = get_or_make_questions_subdir!
        @quiz.questions.each do |q|
          @plq = Ruql::Prairielearn::Question.new(q,@partial_credit,@extra_tags,@default_topic,questions_path)
          if @omit_tags.any? { |t| q.tags.include? t }
            @output << "  Skip #{@plq.digest}"
            next
          end
          @plq.create_question_files!
          @output << "Create #{File.basename questions_path}/#{File.basename @plq.question_dir} topic=#{@plq.topic} tags=[#{@plq.tags.join ','}]\n"
        end
        self
      rescue StandardError => e
        raise e
        puts "Exiting: #{e.backtrace}"
        Ruql::Prairielearn::Question.clean_up_after_error!
      end
    end

    private

    def get_or_make_questions_subdir!
      # if current dir is named 'questions', put things here
      if (File.basename(Dir.pwd) == 'questions')
        File.absolute_path '.'
      # else if a subdir exists with that name, use it
      elsif File.directory?('questions')
        File.absolute_path 'questions'
      else
        # create a questions dir
        Dir.mkdir('questions')
        File.absolute_path 'questions'
      end
    end

  end
end
