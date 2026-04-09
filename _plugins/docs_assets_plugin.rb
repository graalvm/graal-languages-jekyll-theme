require "fileutils"

module GraalLanguages
  class CopyAssets < Liquid::Tag
    @@assets = []

    def initialize(tag_name, text, tokens)
      super
      @@assets << text.strip
    end

    def render(context)
      ""
    end

    Jekyll::Hooks.register :site, :post_write do |site|
      @@assets.each do |a|
        puts "Copying #{a}"
        if File.directory? a
          FileUtils.cp_r a, site.dest
        else
          FileUtils.cp a, site.dest
        end
      end
    end
  end
end

Liquid::Template.register_tag('copy_assets', GraalLanguages::CopyAssets)
