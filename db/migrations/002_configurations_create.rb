require 'sequel'

Sequel.migration do 
	change do
		create_table(:configurations) do
			String :id, type: :uuid, primary_key: true 

			String :filename, null: false
			String :relative_path, null: false, default: './'
			String :description_encrypted, text: true
			String :document_encrypted, text: true
			DateTime :created_at
			DateTime :updated_at

			foreign_key :project_id
			unique [:project_id, :filename]
		end
	end
end