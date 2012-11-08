# This is used for SFX search testing.
# DO NOT USE THIS FOR ANYTHING LIKE A REAL SFX DATABASE.
class Sfx4Local < ActiveRecord::Migration
  def connection
    if sfx4_mock_instance?
      Sfx4::Local::Base.connection.initialize_schema_migrations_table
      return Sfx4::Local::Base.connection
    end
  end

  def change
    if sfx4_mock_instance?
      create_table "AZ_TITLE", {:id => false} do |t|
        t.integer "AZ_TITLE_ID", :default => 0, :null => false
        t.string "AZ_PROFILE", :limit => 100, :null => false
        t.integer "OBJECT_ID", :default => 0, :null => false, :limit => 8
        t.string "TITLE_DISPLAY", :limit => 255, :null => false
        t.string "TITLE_SORT", :limit => 200, :null => false
        t.string "SCRIPT", :limit => 20, :null => false
      end
      execute "ALTER TABLE AZ_TITLE ADD PRIMARY KEY (AZ_TITLE_ID);"

      create_table "AZ_EXTRA_INFO", {:id => false} do |t|
        t.integer "AZ_EXTRA_INFO_ID", :default => 0, :null => false
        t.string "AZ_PROFILE", :limit => 100, :null => false
        t.integer "OBJECT_ID", :default => 0, :null => false, :limit => 8
        t.text "EXTRA_INFO_XML", :limit => 16777215
      end
      execute "ALTER TABLE AZ_EXTRA_INFO ADD PRIMARY KEY (AZ_EXTRA_INFO_ID);"

      create_table "AZ_TITLE_SEARCH", {:id => false} do |t|
        t.integer "AZ_TITLE_SEARCH_ID", :default => 0, :null => false
        t.string "AZ_PROFILE", :limit => 100, :null => false
        t.integer "AZ_TITLE_ID", :default => 0, :null => false
        t.text "TITLE_SEARCH", :null => false
      end
      execute "ALTER TABLE AZ_TITLE_SEARCH ADD PRIMARY KEY (AZ_TITLE_SEARCH_ID);"

      create_table "AZ_LETTER_GROUP", {:id => false} do |t|
        t.integer "AZ_LETTER_GROUP_ID", :default => 0, :null => false
        t.integer "AZ_TITLE_ID", :default => 0, :null => false
        t.string "AZ_LETTER_GROUP_NAME", :limit => 10, :null => false
      end
      execute "ALTER TABLE AZ_LETTER_GROUP ADD PRIMARY KEY (AZ_LETTER_GROUP_ID);"
    else
      puts "Skipping SFX DB migration since the SFX DB specified is not a mock instance."
    end
  end

  def sfx4_mock_instance?
    (ActiveRecord::Base.configurations["sfx_db"] and
      ActiveRecord::Base.configurations["sfx_db"]["mock_instance"])
  end
end