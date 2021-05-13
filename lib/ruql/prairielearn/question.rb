module Ruql
  class Prairielearn
    class Question
      
      attr_reader :tags, :uuid, :title, :topic

      def initialize(question,omit_tags,extra_tags,default_topic)
        @gem_root = Gem.loaded_specs['ruql-html'].full_gem_path rescue '.'
        @question = question
        @omit_tags = omit_tags
        @extra_tags = extra_tags
        @json_template =            File.join(@gem_root, 'info.json.erb')
        @multiple_choice_template = File.join(@gem_root, 'pl-multiple-choice.html.erb')
        @select_multiple_template = File.join(@gem_root, 'pl-checkbox.html.erb')
        @uuid = SecureRandom.uuid
        @tags = @question.question_tags
        @topic = (t = @tags.any? { |tag| tag =~ /^topic:/ }) ?
                   @tags.delete(t).gsub(/^topic:/, '') :
                   default_topic
        @tags += extra_tags
      end

      def should_skip?
        if @omit_tags.any? { |t| tags.include? t }
          STDERR.puts %Q{Skipping: #{@question.question_text.strip[0,40] + '...'}}
          true
        else
          nil
        end
      end
    end
  end
end


    
