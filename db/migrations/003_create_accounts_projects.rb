require 'sequel'

Sequel.migration do 
	change do
		create_join_table(contributor_id: :accounts, project_id: :projects)
	end
end