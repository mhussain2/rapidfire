module Rapidfire
  class QuestionForm < Rapidfire::BaseService
    AVAILABLE_QUESTIONS =
      [
       Rapidfire::Questions::Checkbox,
       Rapidfire::Questions::Date,
       Rapidfire::Questions::Long,
       Rapidfire::Questions::Numeric,
       Rapidfire::Questions::Radio,
       Rapidfire::Questions::Select,
       Rapidfire::Questions::Short,
       Rapidfire::Questions::File,
      ]

    QUESTION_TYPES = AVAILABLE_QUESTIONS.inject({}) do |result, question|
      question_name = question.to_s.split("::").last
      result[question_name] = question.to_s
      result
    end

    attr_accessor :survey, :question, :default_text, :placeholder, :multi_select, :required,
      :question_type, :question_text, :position, :active, :answer_options, :answer_presence,
      :answer_minimum_length, :answer_maximum_length,
      :answer_greater_than_or_equal_to, :answer_less_than_or_equal_to

    delegate :valid?, :errors, :to => :question

    def initialize(params = {})
      from_question_to_attributes(params[:question]) if params[:question]
      super(params)
      @question ||= survey.questions.new
    end

    def save
      @question.new_record? ? create_question : update_question
    end

    private
    def create_question
      klass = nil
      if QUESTION_TYPES.values.include?(question_type)
        klass = question_type.constantize
      else
        errors.add(:question_type, :invalid)
        return false
      end

      @question = klass.create(to_question_params)
    end

    def update_question
      @question.update_attributes(to_question_params)
    end

    def to_question_params
      {
        :survey => survey,
        :question_type  => question_type,
        :question_text  => question_text,
        :position => position,
        :active => active,
        :default_text => default_text,
        :placeholder => placeholder,
        :multi_select => multi_select,
        :required => required,
        :answer_options => answer_options,
        :validation_rules => {
          :presence => answer_presence,
          :minimum  => answer_minimum_length,
          :maximum  => answer_maximum_length,
          :greater_than_or_equal_to => answer_greater_than_or_equal_to,
          :less_than_or_equal_to    => answer_less_than_or_equal_to
        }
      }
    end

    def from_question_to_attributes(question)
      self.question_type = question.question_type
      self.survey  = question.survey
      self.question_text   = question.question_text
      self.position = question.position
      self.active = question.active
      self.default_text    = question.default_text
      self.placeholder     = question.placeholder
      self.multi_select = question.multi_select
      self.required = question.required
      self.answer_options  = question.answer_options
      self.answer_presence = question.rules[:presence]
      self.answer_minimum_length = question.rules[:minimum]
      self.answer_maximum_length = question.rules[:maximum]
      self.answer_greater_than_or_equal_to = question.rules[:greater_than_or_equal_to]
      self.answer_less_than_or_equal_to    = question.rules[:less_than_or_equal_to]
    end
  end
end
