module Pageflow
  class DraftEntry
    include ActiveModel::Conversion

    attr_reader :entry, :draft

    delegate(:id,
             :edit_lock, :account, :theming, :slug,
             :enabled_feature_names,
             :published_until, :published?,
             :password_digest,
             :to_model, :to_key, :persisted?, :to_json,
             :to => :entry)

    delegate(:title, :summary, :credits, :manual_start,
             :widgets,
             :storylines, :main_storyline_chapters, :chapters, :pages,
             :emphasize_chapter_beginning,
             :emphasize_new_pages,
             :share_image_id, :share_image_x, :share_image_y,
             :files,
             :image_files, :video_files, :audio_files,
             :locale,
             :author, :publisher, :keywords,
             :to => :draft)

    def initialize(entry, draft = nil)
      @entry = entry
      @draft = draft || entry.draft
    end

    # So we can always get to the original Entry title.
    def entry_title
      entry.title
    end

    def create_file(model, attributes)
      file = model.create(attributes) do |f|
        f.entry = entry
      end

      usage = @draft.file_usages.create(:file => file)
      file.usage_id = usage.id

      file
    end

    def remove_file(file)
      draft.file_usages.where(file: file).destroy_all
      file.destroy if file.usages.empty?
    end

    def add_file(file)
      draft.file_usages.create!(:file => file)
    end

    def save!
      draft.save!
    end

    def update_meta_data!(attributes)
      draft.update_attributes!(attributes)
    end

    def self.find(id)
      new(Entry.find(id))
    end

    def self.for_file_usage(usage)
      new(usage.revision.entry)
    end

    def self.accessible_by(ability, action)
      Entry.includes(:draft).accessible_by(ability, action).map do |entry|
        DraftEntry.new(entry)
      end
    end

    def stylesheet_model
      draft
    end

    def stylesheet_cache_key
      draft.cache_key
    end

    def home_button
      HomeButton.new(draft, theming)
    end

    def overview_button
      OverviewButton.new(draft, theming)
    end

    def resolve_widgets(options = {})
      widgets.resolve(Pageflow.config_for(entry), options)
    end
  end
end
