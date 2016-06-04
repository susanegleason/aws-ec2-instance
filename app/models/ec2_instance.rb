class Ec2Instance
  attr_accessor :ec2instance_params

  def initialize(ec2instance_params)
    @ec2instance_params = ec2instance_params
    @ec2 = Aws::EC2::Client.new(region: region)
  end

  def list
    instance_list = []
    if client_resp = ec2.describe_instances
      client_resp.reservations.each do |instance|
        instance_list << {
          'Instance id' => instance.instances[0].instance_id,
          'Instance name' => instance_name(instance.instances[0]),
          'State' => instance.instances[0].state.name }
      end
    end
    instance_list
  end

  def details
    if instance_response = description
      build_instance_details(instance_response)
    end
  end

  def start
    if state == 'stopped'
      start_resp = ec2.start_instances(instance_ids: [id])
      start_resp.starting_instances[0].current_state.name
      "Instance #{id} starting"
    elsif state
      'Error: instance must be stopped to start'
    end
  end

  def stop
    if state == 'running'
      stop_resp = ec2.stop_instances(instance_ids: [id])
      stop_resp.stopping_instances[0].current_state.name
      "Instance #{id} stopping"
    elsif state
      'Error: instance must be running to stop'
    end
  end

  def state
    desc_resp = description
    if desc_resp
      description.state.name
    end
  end

  def description
    client_resp = ec2.describe_instances({
      filters: [{ name: 'instance-id', values: [id] }] })
    if client_resp.reservations.any?
      client_resp.reservations[0].instances[0]
    end
  end

  private

  def build_instance_details(instance)
    { 'Instance id' => instance.instance_id,
      'Instance name' => instance_name(instance),
      'Instance type' => instance.instance_type,
      'State' => instance.state.name,
      'Public DNS' => instance.public_dns_name,
      'Public IP' => instance.public_ip_address,
      'Private DNS' => instance.private_dns_name,
      'Private IP' => instance.private_ip_address }
  end

  def instance_name(instance)
    instance.tags.each do |tag|
      return tag.value if tag.key == 'Name'
    end
  end

  def region
    if ec2instance_params[:region].nil?
      'us-east-1'
    else
      ec2instance_params[:region]
    end
  end

  def id
    ec2instance_params[:id]
  end

  def ec2
    @ec2
  end
end
