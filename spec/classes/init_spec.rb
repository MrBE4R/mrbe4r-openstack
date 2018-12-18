require 'spec_helper'
describe 'openstack' do
  context 'with default values for all parameters' do
    it { should contain_class('openstack') }
  end
end
