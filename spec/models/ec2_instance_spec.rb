require 'rails_helper.rb'

describe Ec2Instance do
  before(:all) do
    Aws.config.update(stub_responses: true)
  end

  describe '.list' do
    context 'given an instance is defined' do
      it 'returns a list with info of one instance' do
        Aws.config[:ec2] = instance_exists_stub

        instance = Ec2Instance.new(id: 'id-exists', region: 'us-east-1')
        instance_list = instance.list

        expect(instance_list[0]['Instance id']).to be
        expect(instance_list[0]['Instance name']).to be
        expect(instance_list[0]['State']).to be
      end
    end

    context 'given there are no instances defined' do
      it 'returns an empty array' do
        Aws.config[:ec2] = instance_does_not_exist_stub

        instance = Ec2Instance.new(id: 'id-not-exist', region: 'us-east-1')
        instance_list = instance.list

        expect(instance_list).to be_empty
      end
    end
  end

  describe '.description' do
    context 'given an existing instance' do
      it 'returns instance description' do
        Aws.config[:ec2] = instance_exists_stub

        instance = Ec2Instance.new(id: 'id-exists', region: 'us-east-1')
        response = instance.description

        expect(response.instance_id).to be
        expect(response.state.name).to be
        expect(response.tags[0].value).to be
      end
    end

    context 'given an instance that does not exist' do
      it 'returns nil' do
        Aws.config[:ec2] = instance_does_not_exist_stub

        instance = Ec2Instance.new(id: 'id-not-exist', region: 'us-east-1')
        response = instance.description

        expect(response).to eq(nil)
      end
    end
  end

  describe '.start' do
    context 'given an existing stopped instance' do
      it 'starts the instance and returns the current state as pending' do
        Aws.config[:ec2] = starting_instance_stub


        instance = Ec2Instance.new(id: 'id-exists', region: 'us-east-1')
        response = instance.start

        expect(response).to eql('Instance id-exists starting')
      end
    end

    context 'given an existing instance that is not stopped' do
      it 'does not attempt to start it and returns error message' do
        Aws.config[:ec2] = running_instance_stub

        instance = Ec2Instance.new(id: 'id-exists', region: 'us-east-1')
        response = instance.start

        expect(response).to eql('Error: instance must be stopped to start')
      end
    end

    context 'given an instance that does not exist' do
      it 'does not attempt to start it and returns nil' do
        Aws.config[:ec2] = instance_does_not_exist_stub

        instance = Ec2Instance.new(id: 'id-not-exist', region: 'us-east-1')
        response = instance.start

        expect(response).to eq(nil)
      end
    end
  end

  describe '.stop' do
    context 'given an existing running instance' do
      it 'stops the instance and returns the current state as stopping' do
        Aws.config[:ec2] = stopping_instance_stub


        instance = Ec2Instance.new(id: 'id-exists', region: 'us-east-1')
        response = instance.stop

        expect(response).to eql('Instance id-exists stopping')
      end
    end

    context 'given an existing instance that is not running' do
      it 'does not attempt to stop it and returns error message' do
        Aws.config[:ec2] = stopped_instance_stub

        instance = Ec2Instance.new(id: 'id-exists', region: 'us-east-1')
        response = instance.stop

        expect(response).to eql('Error: instance must be running to stop')
      end
    end

    context 'given an instance id that does not exist' do
      it 'returns nil' do
        Aws.config[:ec2] = instance_does_not_exist_stub

        instance = Ec2Instance.new(id: 'id-not-exist', region: 'us-east-1')
        response = instance.stop

        expect(response).to eq(nil)
      end
    end
  end

  describe '.state' do
    context 'given an existing instance' do
      it 'returns the instance state name' do
        Aws.config[:ec2] = instance_exists_stub

        instance = Ec2Instance.new(id: 'id-exists', region: 'us-east-1')
        response = instance.state

        expect(response).to eql('pending')
      end
    end

    context 'given an instance that does not exist' do
      it 'returns nil' do
        Aws.config[:ec2] = instance_does_not_exist_stub

        instance = Ec2Instance.new(id: 'id-not-exist', region: 'us-east-1')
        response = instance.state

        expect(response).to eq(nil)
      end
    end
  end
end

private

def instance_does_not_exist_stub
  { stub_responses: {
      describe_instances: { reservations: [] } } }
end

def stopped_instance_stub
  { stub_responses: {
      describe_instances: { reservations: [ instances: [
        instance_id: 'id-exists',
        state: { name: 'stopped' },
        tags: [{ value: 'name-exists' }]]] } } }
end

def instance_exists_stub
  { stub_responses: {
      describe_instances: { reservations: [ instances: [
        instance_id: 'id-exists',
        state: { name: 'pending' },
        tags: [{ value: 'name-exists' }]]] } } }
end

def running_instance_stub
  { stub_responses: {
      describe_instances: { reservations: [ instances: [
        instance_id: 'id-exists',
        state: {name: 'running'},
        tags: [{ value: 'name-exists' }]]] } } }
end

def starting_instance_stub
  { stub_responses: {
      describe_instances: { reservations: [ instances: [
        instance_id: 'id-exists',
        state: { name: 'stopped' },
        tags: [{ value: 'name-exists' }]]] },
      start_instances: { starting_instances: [{
        current_state: { name: 'pending' } }] } } }
end

def stopping_instance_stub
  { stub_responses: {
      describe_instances: { reservations: [ instances: [
        instance_id: 'id-exists',
        state: {name: 'running'},
        tags: [{ value: 'name-exists' }]]] },
      stop_instances: { stopping_instances: [{
        current_state: { name: 'stopping' } }] } } }
end
