# frozen_string_literal: true
module ThemeCheck
  class RemoteAsset < HtmlCheck
    severity :suggestion
    categories :html, :performance
    doc docs_url(__FILE__)

    TAGS = %w[img script link source]
    PROTOCOL = %r{(https?:)?//}
    ABSOLUTE_PATH = %r{\A/[^/]}im
    RELATIVE_PATH = %r{\A(?!#{PROTOCOL})[^/\{]}oim
    CDN_ROOT = "https://cdn.shopify.com/"

    def on_element(node)
      return unless TAGS.include?(node.name)

      resource_url = node.attributes["src"] || node.attributes["href"]
      return if resource_url.nil? || resource_url.empty?

      # Ignore if URL is Liquid, taken care of by AssetUrlFilters check
      return if resource_url.start_with?(CDN_ROOT)
      return if resource_url =~ ABSOLUTE_PATH
      return if resource_url =~ RELATIVE_PATH
      return if url_hosted_by_shopify?(resource_url)
      return if url_is_setting_variable?(resource_url)

      # Ignore non-stylesheet link tags
      rel = node.attributes["rel"]
      return if node.name == "link" && rel != "stylesheet"

      add_offense(
        "Asset should be served by the Shopify CDN for better performance.",
        node: node,
      )
    end

    private

    def url_hosted_by_shopify?(url)
      url.start_with?(Liquid::VariableStart) &&
        AssetUrlFilters::ASSET_URL_FILTERS.any? { |filter| url.include?(filter) }
    end

    def url_is_setting_variable?(url)
      url.start_with?(Liquid::VariableStart) && url =~ /settings\./
    end
  end
end
