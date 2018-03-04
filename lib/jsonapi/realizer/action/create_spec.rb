require "spec_helper"

RSpec.describe JSONAPI::Realizer::Action::Create do
  let(:action) { described_class.new(payload: payload, headers: headers) }

  describe "#call" do
    subject { action.call }

    context "with a good payload and good headers" do
      let(:payload) do
        {
          "data" => {
            "id" => "550e8400-e29b-41d4-a716-446655440000",
            "type" => "photos",
            "attributes" => {
              "title" => "Ember Hamster",
              "src" => "http://example.com/images/productivity.png"
            },
            "relationships" => {
              "photographer" => {
                "data" => { "type" => "people", "id" => "4b8a0af6-953d-4729-8b9a-1fa4eb18f3c9" }
              }
            }
          }
        }
      end
      let(:headers) do
        {
          "Content-Type" => "application/vnd.api+json",
          "Accept" => "application/vnd.api+json"
        }
      end

      before do
        People::STORE["4b8a0af6-953d-4729-8b9a-1fa4eb18f3c9"] = {
          id: "4b8a0af6-953d-4729-8b9a-1fa4eb18f3c9",
          name: "Kurtis Rainbolt-Greene"
        }
      end

      it "creates a model" do
        expect(subject).to be_a_kind_of(Photo)
      end

      it "assigns the attributes" do
        expect(subject).to have_attributes(title: "Ember Hamster", src: "http://example.com/images/productivity.png", updated_at: a_kind_of(Time))
      end

      it "relates the relationships" do
        expect(subject).to have_attributes(photographer: a_kind_of(People))
      end

      it "stores the new record" do
        expect {subject}.to change {Photo::STORE}.from({}).to({"550e8400-e29b-41d4-a716-446655440000" => hash_including(id: "550e8400-e29b-41d4-a716-446655440000", title: "Ember Hamster", src: "http://example.com/images/productivity.png")})
      end
    end
  end
end