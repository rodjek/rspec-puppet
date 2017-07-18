module Jekyll
  class Callout < Liquid::Block
    def initialize(tag_name, type, tokens)
      super
      @callout_type = type
    end

    def render(context)
      text = super
      site = context.registers[:site]
      converter = site.find_converter_instance(::Jekyll::Converters::Markdown)
      callout_content = converter.convert(text)
      [
        "<div class=\"callout-block callout-#{@callout_type}\">",
        "<div class=\"icon-holder\"><i class=\"fa fa-#{@callout_type}-circle\"></i></div>",
        '<div class="content">',
        callout_content,
        '</div>',
        '</div>',
      ].join("\n")
    end
  end
end

Liquid::Template.register_tag('callout', Jekyll::Callout)
