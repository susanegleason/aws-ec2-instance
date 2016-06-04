class InstancesController < ApplicationController

  def index
    ec2_instance = Ec2Instance.new(region: 'us-east-1')
    @list = ec2_instance.list
    if @list.nil?
      flash.now[:error] = "No instances defined"
    end
  end

  def show
    @id = params[:id]
    ec2_instance = Ec2Instance.new(id: @id)
    @details = ec2_instance.details
    if @details.nil?
      flash.now[:error] = "Instance does not exist"
    end

  end

  def start
    @id = params[:instance_id]
    ec2_instance = Ec2Instance.new(id: @id)
    redirect_to instance_url(@id), notice: ec2_instance.start
  end

  def stop
    @id = params[:instance_id]
    ec2_instance = Ec2Instance.new(id: @id)
    redirect_to instance_url(@id), notice: ec2_instance.stop
  end

end
