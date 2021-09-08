class Api::V1::OrganisationsController < Api::V1::ApiController
  skip_before_action :verify_authenticity_token
  protect_from_forgery with: :null_session

  def index
    organisations = Organisation.select(:id, :name)
    json_success("Fetched.", organisations);
  end

  def create
    organisation = Organisation.new(organisation_params)
    if organisation.save
      json_success("Organisation saved successfully", organisation);
    else
      json_bad_request(user.errors.full_messages.to_sentence)
    end
  end

  def update
    organisation = Organisation.find_by(id: params[:id])
    organisation.assign_attributes(organisation_params)
    if organisation.save
      json_success("Organisation updated successfully", organisation);
    else
      json_bad_request(user.errors.full_messages.to_sentence)
    end
  end

  private
  def organisation_params
    params.require(:organisation).permit(
      "name",
      "phone_no",
      "email",
      "help_desk_info",
      "customer_contact",
      "additional_info",
      "active"
    )
  end

end
