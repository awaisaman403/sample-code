module Traveler
  class DeliverDeadlineReminderEmails
    def execute
      deliver_application_reminders
      deliver_form_reminders
    end

    private

    def deliver_application_reminders
      deadline_dates.each do |date|
        TravelerApplication.incomplete
          .select { |tapp| tapp.deadline_date.present? && tapp.deadline_date == date }
          .each do |tapp|

          Traveler::DeadlineReminderMailer.email(
            tapp.user_id,
            tapp.client_account_application.client_account_id,
            tapp.class.name,
            tapp.id,
            date.to_s
          ).deliver_later
        end
      end
    end

    def deliver_form_reminders
      deadline_dates.each do |date|
        FormSubmission.includes(program_range: :form_groupings)
          .where(form_groupings: { deadline: date } )
          .incomplete
          .each do |submission|

          Traveler::DeadlineReminderMailer.email(
            submission.user_id,
            submission.form.client_account_id,
            submission.class.name,
            submission.id,
            date.to_s
          ).deliver_later
        end
      end
    end

    def deadline_dates
      [
        Time.zone.today + 1.day,
        Time.zone.today + 7.days,
        Time.zone.today + 10.days
      ]
    end
  end
end
