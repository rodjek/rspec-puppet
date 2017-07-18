module Jekyll
  class ViewDiffTag < Liquid::Tag
    def initialize(tag_name, input, tokens)
      super
      @version = input
    end

    def render(context)
      "<a href=\"https://github.com/rodjek/rspec-puppet/compare/#{@version}\" class=\"btn btn-primary btn-inline pull-right\">View Diff</a>"
    end
  end
end

Liquid::Template.register_tag('view_diff', Jekyll::ViewDiffTag)
