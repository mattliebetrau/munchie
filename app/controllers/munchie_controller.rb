class MunchieController < ApplicationController
  def munch
    render :text => MunchInteractor.munch(params)
  end
end
