require 'sequel'

Sequel.migration do 
	change do
		create_table(:configurations) do
			String :id, type: :uuid, primary_key: true 
			foreign_key :project_id

			String :filename, null: false
			String :relative_path, null: false, default: './'
			String :description_encrypted, text: true
			String :document_encrypted, text: true
			String :nonce_64

			unique [:project_id, :filename]
		end
	end
end