require_relative './spec_helper'
require './models/init'

describe 'Test creating configuration resources' do 
	before do
		Project.dataset.delete
		Configuration.dataset.delete
	end

	it 'should catch duplicate config files within a project' do
		p = Project.create(name: 'class_demo')
		p.add_configuration(filename: 'filename.rb')
		duplicate_call = -> { p.add_configuration(filename: 'filename.rb') }
		_(duplicate_call).must_raise Sequel::UniqueConstraintViolation 
	end
end