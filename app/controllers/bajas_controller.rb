class BajasController < ApplicationController
  load_and_authorize_resource
  #before_action :establece_usuario_actual, only: [:create]

  def index
    if params[:barcode].present?
      barcode = params[:barcode]
      activos = Asset.buscar_por_barcode(barcode)
      render json: activos, root: false
    else
      format_to('assets', AssetsDatatable)
    end
  end

  def new
    @baja = Baja.new(fecha:  Date.today)
  end

  def create
    @baja = Baja.new(baja_params)
    respond_to do |format|
      if @baja.save
        format.html { redirect_to @baja, notice: 'Ingreso creado exitosamente' }
        format.json { render json: @baja, status: :created }
      else
        format.html { render :new }
        format.json { render json: @baja.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def baja_params
    params.require(:baja).permit(:documento, :fecha, :observacion)
  end
end
