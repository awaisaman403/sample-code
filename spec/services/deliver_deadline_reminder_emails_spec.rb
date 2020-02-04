require "rails_helper"

describe Traveler::DeliverDeadlineReminderEmails do
  describe "#execute" do
    let(:mailer) { double(deliver_later: nil) }

    subject { described_class.new.execute }

    shared_examples "necessary email reminder" do
      before { allow(Traveler::DeadlineReminderMailer).to receive(:email).with(*expected_attrs).and_return(mailer) }

      it "sends reminder email" do
        expect(mailer).to receive(:deliver_later)
        subject
      end
    end

    context "traveler applications" do
      let(:program_range) { FactoryGirl.create(:program_range, deadline: date) }

      context "when traveler application is incomplete" do
        let!(:tapp) { FactoryGirl.create(:traveler_application, program_range: program_range, tapp_status: :incomplete) }
        let(:expected_attrs) do
          [
            tapp.user_id,
            tapp.client_account_application.client_account_id,
            tapp.class.name,
            tapp.id,
            date.to_s
          ]
        end

        context "and it is 10 days from deadline" do
          let(:date) { Time.zone.today + 10.days }

          it_behaves_like "necessary email reminder"
        end

        context "and it is 7 days from deadline" do
          let(:date) { Time.zone.today + 7.days }

          it_behaves_like "necessary email reminder"
        end

        context "and it is 1 day from deadline" do
          let(:date) { Time.zone.today + 1.days }

          it_behaves_like "necessary email reminder"
        end

        context "and it is 5 days from deadline" do
          let(:date) { Time.zone.today + 5.days }

          it "does not sends reminder email" do
            expect(Traveler::DeadlineReminderMailer).not_to receive(:email)
            subject
          end
        end
      end

      context "when traveler application is not incomplete" do
        let(:date) { Time.zone.today + 10.days }
        let!(:tapp) { FactoryGirl.create(:traveler_application, program_range: program_range, tapp_status: :accepted) }

        it "does not sends reminder email" do
          expect(Traveler::DeadlineReminderMailer).not_to receive(:email)
          subject
        end
      end
    end

    context "form submissions" do
      let(:admin) { FactoryGirl.create(:admin) }
      let(:traveler) { FactoryGirl.create(:traveler) }
      let(:client_account) { FactoryGirl.create(:client_account) }
      let(:program_range) { FactoryGirl.create(:program_range, deadline: date) }
      let(:form) { FactoryGirl.create(:form, client_account: client_account, user: admin) }
      let(:form_grouping) { FactoryGirl.create(:form_grouping, program_range: program_range, deadline: date) }

      before { form_grouping.forms << form }

      context "when form submission is incomplete" do
        let!(:submission) { FactoryGirl.create(:form_submission, form: form, user: traveler, program_range: program_range, status: :incomplete) }
        let(:expected_attrs) do
          [
            submission.user_id,
            form.client_account_id,
            submission.class.name,
            submission.id,
            date.to_s
          ]
        end

        context "and it is 10 days from deadline" do
          let(:date) { Time.zone.today + 10.days }

          it_behaves_like "necessary email reminder"
        end

        context "and it is 7 days from deadline" do
          let(:date) { Time.zone.today + 7.days }

          it_behaves_like "necessary email reminder"
        end

        context "and it is 1 day from deadline" do
          let(:date) { Time.zone.today + 1.days }

          it_behaves_like "necessary email reminder"
        end

        context "and it is 5 days from deadline" do
          let(:date) { Time.zone.today + 5.days }

          it "does not sends reminder email" do
            expect(Traveler::DeadlineReminderMailer).not_to receive(:email)
            subject
          end
        end
      end

      context "when form submission is not incomplete" do
        let(:date) { Time.zone.today + 10.days }
        let!(:submission) { FactoryGirl.create(:form_submission, form: form, user: traveler, program_range: program_range, status: :completed) }

        it "does not sends reminder email" do
          expect(Traveler::DeadlineReminderMailer).not_to receive(:email)
          subject
        end
      end
    end
  end
end
