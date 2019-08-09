require("spec_helper")

RSpec.describe(JSONAPI::Realizer::Resource) do
  let(:headers) do
    {
      "Accept" => "application/vnd.api+json",
      "Content-Type" => "application/vnd.api+json"
    }
  end
  let(:resource_class) {PhotoRealizer}
  let(:resource) {resource_class.new(intent: intent, parameters: parameters, headers: headers)}

  describe "#as_native" do
    let(:subject) {resource}

    context "when accepting the right type, when creating with data, with spares fields, and includes" do
      let(:intent) {:create}
      let(:parameters) do
        {
          "include" => "photographer",
          "fields" => {
            "articles" => "title,body,sub-text",
            "people" => "name"
          },
          "data" => {
            "type" => "photos",
            "attributes" => {
              "title" => "Ember Hamster",
              "src" => "http://example.com/images/productivity.png"
            },
            "relationships" => {
              "photographer" => {
                "data" => {
                  "type" => "people",
                  "id" => "9"
                }
              }
            }
          }
        }
      end
      let(:headers) do
        {
          "Accept" => "application/vnd.api+json",
          "Content-Type" => "application/vnd.api+json"
        }
      end

      before do
        Account.create!(:id => 9, :name => "Dan Gebhardt", :twitter => "dgeb")
      end

      it "object is a Photo" do
        expect(subject.object).to be_kind_of(Photo)
      end

      it "object isn't saved" do
        expect(subject.object).to_not be_persisted()
      end

      it "object has the right attributes" do
        expect(subject.object).to have_attributes(
          :title => "Ember Hamster",
          :src => "http://example.com/images/productivity.png"
        )
      end

      it "has a photographer" do
        expect(subject.object.photographer).not_to be_nil
      end
    end

    context "with existing resources" do
      before(:each) do
        account = Account.create!(:id => 9, :name => "Dan Gebhardt", :twitter => "dgeb")
        Photo.create!(:id => 11, :photographer => account, :title => "Ember Hamster", :src => "http://example.com/images/productivity.png")
        Photo.create!(:id => 12, :photographer => account, :title => "Icicle Hamster", :src => "http://example.com/images/laziness.png")
      end

      context "viewing filtered resources" do
        let(:intent) {:show}
        let(:parameters) do
          {
            "id" => "11",
            "data" => {
              "id" => "11",
              "type" => "photos"
            },
            "filter" => {
              "title" => "Icicle Hamster"
            }
          }
        end

        it "returns exactly one photo" do
          expect(subject.total_count).to eq(1)
        end
      end

      context "clearing relationship" do
        let(:intent) {:update}
        let(:parameters) do
          {
            "id" => "11",
            "data" => {
              "id" => "11",
              "type" => "photos",
              "relationships" => {
                "photographer" => nil
              }
            }
          }
        end

        it "object is a Photo" do
          expect(subject.object).to be_kind_of(Photo)
        end

        it "clears relationship on realizing nil" do
          subject.object.save!
          expect(subject.object.photographer).to be_nil
        end

        it "clears relationships on realizing nil 2" do
          expect(PhotoRealizer.new(intent: :update, parameters:
            {
              "id" => "12",
              "data" => {
                "id" => "12",
                "type" => "photos",
                "relationships" => {
                  "photographer" => nil
                }
              }
            }, headers: headers).object.photographer).to be_nil
        end
      end
    end
  end
end
