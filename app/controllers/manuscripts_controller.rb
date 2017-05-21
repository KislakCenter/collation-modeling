class ManuscriptsController < ApplicationController
  before_action :set_manuscript, only: [:edit, :update, :destroy, :export_xml]
  before_action :set_manuscript_eagerly, only: [:show]

  respond_to :html, :xml

  def index
    @manuscripts = Manuscript.all
    respond_with(@manuscripts)
  end

  def export_xml
    xml_type = params['xml_type'] || :filled_quires
    send_data  "#{@manuscript.to_xml(xml_type: xml_type.to_sym)}", filename: xml_file_name
  end

  def show
    respond_with(@manuscript)
  end

  def new
    @manuscript = Manuscript.new
    respond_with(@manuscript)
  end

  def edit
  end

  def create
    @manuscript = Manuscript.new(manuscript_params)
    @manuscript.save
    respond_with(@manuscript)
  end

  def update
    @manuscript.update(manuscript_params)
    respond_with(@manuscript)
  end

  def destroy
    @manuscript.destroy
    respond_with(@manuscript)
  end

  private
  def xml_file_name
    "#{@manuscript.shelfmark.strip.gsub /\s+/, '_'}.xml"
  end

  def set_manuscript
    @manuscript = Manuscript.find(params[:id])
  end

  def set_manuscript_eagerly
    @manuscript = Manuscript.includes(quires: :leaves).find(params[:id])
  end

  def manuscript_params
    params.require(:manuscript).permit(:title, :shelfmark, :url, :quire_number_input, :leaves_per_quire_input)
  end
end
