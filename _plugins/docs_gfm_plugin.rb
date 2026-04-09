require 'kramdown'
require 'kramdown-parser-gfm'

module GraalLanguages
  class GfmDocs < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @text = text.strip
    end

    def md(filename)
      content = File.read(filename)
      # strip yaml header, if any
      content.sub!(/---.*?---/m, "") if content.start_with? "---"
      Kramdown::Document.new(
        content,
        input: 'GFM',
        header_links: true,
        header_offset: 1,
        hard_wrap: false,
        # syntax_highlighter: 'none',
        # syntax_highlighter_opts: { disable: true }
      )
    end

    def dfs(element, &block)
      element.children.each do |child|
        res = block.call(child)
        return res if res
        dfs(child, &block)
      end
    end

    def render(context)
      page = md(@text)
      baseurl = "#{context['site']['baseurl']}"

      dfs(page.root) do |child|
        # replace any relative link to another markdown file with a ref link for
        # single page references
        if child.type == :a && child.attr['href'] =~ /^((?:\.\/|[A-Z]).*\.md)(\#[^\#]+)?$/ then
          filename, hash = $~[1], $~[2]
          if hash
            ref = hash[1..]
          else
            filename = File.join(File.dirname(@text), $~[1])
            referenced_document = md(filename)
            ref = dfs(referenced_document.root) do |e|
              e.attr['id'] if e.type == :header
            end
          end
          puts "Converting link #{child.attr['href']} => ##{ref}"
          child.attr['href'] = "##{ref}"
          nil
        end

        # add anchor links to headers
        if child.type == :header and child.attr['id'] then
          unless child.children.any? { |header_child| header_child.type == :a }
            text = child.children.first { |header_child| header_child.type == :text }
            inner_text = text.dup
            text.type = :a
            text.attr['href'] = "##{child.attr['id']}"
            text.attr['class'] = "anchor-link"
            text.children = [inner_text]
          end
        end

        # fixup any relative img-src to ./assets/
        if child.type == :img && child.attr['src'] =~ /^\.\/assets\// then
          new_src = "#{baseurl}#{child.attr['src'][1..-1]}"
          puts "Converting img-src #{child.attr['src']} => #{new_src}"
          child.attr['src'] = new_src
          nil
        end
      end

      page.to_html
    end
  end
end

Liquid::Template.register_tag('gfm_docs', GraalLanguages::GfmDocs)
