module Ruql
  class Prairielearn
    class Question
      require 'securerandom'      # for uuid generation
      require 'erb'
      require 'fileutils'
      
      attr_reader :question, :partial_credit, :tags, :uuid, :topic, :title, :question_dir, :digest, :none_of_the_above

      @@dirnames = {} # keep track of titles seen, since subdir names must be unique

      def initialize(question,partial_credit,extra_tags,default_topic,path='.')
        @gem_root = Gem.loaded_specs['ruql-prairielearn'].full_gem_path
        @@path ||= path
        @question = question
        @partial_credit = partial_credit
        @extra_tags = extra_tags
        @json_template =            File.join(@gem_root, 'templates', 'info.json.erb')
        @multiple_choice_template = File.join(@gem_root, 'templates', 'pl-multiple-choice.html.erb')
        @select_multiple_template = File.join(@gem_root, 'templates', 'pl-checkbox.html.erb')
        @uuid = SecureRandom.uuid
        @tags = @question.question_tags
        @digest = @question.question_text.strip[0,40] + '...'
        @title = (@tags.empty? ? @uuid : @tags.shift)
        @title = @title.capitalize unless @title =~ /[A-Z]/ # Capitalize if all lowercase
        @topic = (t = @tags.detect { |tag| tag =~ /^topic:/ }) ?
                   @tags.delete(t).gsub(/^topic:/, '') :
                   default_topic
        if (group = question.question_group.to_s) != ''
          @tags << "group:#{group}"
        end
        @tags += extra_tags
        @none_of_the_above = question.answers.any? { |a| a =~ /^none of (these|the above)$/i }
        @question_dir = nil
      end

      def create_question_files!
        begin
          @question_dir = dirname()
          Dir.mkdir(@question_dir) unless File.directory?(@question_dir)
          create_json!
          create_question_html!
        rescue RuntimeError => e
          raise Ruql::QuizContentError.new(e.message)
        end
      end

      # If anything goes wrong, delete any files we created
      def self.clean_up_after_error!
        @@dirnames.each_pair do |dir,num|
          fullpath = File.join(@@path,dir)
          STDERR.puts "delete #{fullpath}"
          FileUtils.rm_rf fullpath
          if num > 1
            2.upto(num).each do |otherdir|
              fullpath = File.join(@@path,"#{dir}_#{otherdir}")
              STDERR.puts "delete #{fullpath}"
              FileUtils.rm_rf fullpath
            end
          end
        end
      end
      
      private

      def create_json!
        json = ERB.new(IO.read(File.expand_path @json_template),nil,'-').result(binding)
        File.open(File.join(@question_dir, 'info.json'), 'w') do |f|
          f.puts json
        end
      end

      def create_question_html!
        case question
        when MultipleChoice then template = @multiple_choice_template
        when SelectMultiple then template = @select_multiple_template
        else raise Ruql::QuizContentError.new("Unknown question type: '#{@digest}'")
        end
        html = ERB.new(IO.read(File.expand_path template),nil,'-').result(binding)
        File.open(File.join(@question_dir, 'question.html'), 'w') do |f|
          f.puts html
        end
      end
      
      def dirname
        try_name = @title.downcase.
                     gsub( /[^a-z0-9\-]+/i, '_'). # replace special chars with underscore
                     gsub( /^_+/, '').            # remove leading special chars
                     gsub( /_+$/, '')             # remove trailing special chars
        # make sure filename doesn't end up blank after all the substitution
        try_name += '0' if try_name == ''
        if @@dirnames.has_key?(try_name)
          @@dirnames[try_name] += 1
          try_name << "_#{@@dirnames[try_name]}"
        else
          @@dirnames[try_name] = 1
        end
        File.join(@@path, try_name)
      end
    end
  end
end


    
