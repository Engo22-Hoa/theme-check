# frozen_string_literal: true
require "test_helper"

class SpaceInsideBracesTest < Minitest::Test
  def test_reports_missing_space
    offenses = analyze_theme(
      ThemeCheck::SpaceInsideBraces.new,
      "templates/index.liquid" => <<~END,
        {% assign x = 1%}
        {{ x}}
        {{x }}
      END
    )
    assert_offenses(<<~END, offenses)
      Space missing before '%}' at templates/index.liquid:1
      Space missing before '}}' at templates/index.liquid:2
      Space missing after '{{' at templates/index.liquid:3
    END
  end

  def test_reports_extra_space
    offenses = analyze_theme(
      ThemeCheck::SpaceInsideBraces.new,
      "templates/index.liquid" => <<~END,
        {{  x }}
        {% assign x = 1  %}
        {{ x  }}
      END
    )
    assert_offenses(<<~END, offenses)
      Too many spaces after '{{' at templates/index.liquid:1
      Too many spaces before '%}' at templates/index.liquid:2
      Too many spaces before '}}' at templates/index.liquid:3
    END
  end

  def test_reports_extra_space_around_coma
    offenses = analyze_theme(
      ThemeCheck::SpaceInsideBraces.new,
      "templates/index.liquid" => <<~END,
        {% form 'type',  object, key:value %}
        {% endform %}
      END
    )
    assert_offenses(<<~END, offenses)
      Too many spaces after ',' at templates/index.liquid:1
      Space missing after ':' at templates/index.liquid:1
    END
  end

  def test_reports_extra_space_after_colon_in_assign_tag
    offenses = analyze_theme(
      ThemeCheck::SpaceInsideBraces.new,
      "templates/index.liquid" => <<~END,
        {% assign max_width = height | times:  image.aspect_ratio %}
      END
    )
    assert_offenses(<<~END, offenses)
      Too many spaces after ':' at templates/index.liquid:1
    END
  end

  def test_reports_extra_space_in_multiline
    offenses = analyze_theme(
      ThemeCheck::SpaceInsideBraces.new,
      "templates/multiline.liquid" => <<~END,
        {% include 'image-style' with image: featured.featured_image, width: product_width, height: 480,  wrapper_id: wrapper_id,  img_id: img_id %}
      END
    )
    assert_offenses(<<~END, offenses)
      Too many spaces after ',' at templates/multiline.liquid:1
      Too many spaces after ',' at templates/multiline.liquid:1
    END
    assert_equal([
      [97, 100],
      [122, 125],
    ], offenses.map { |o| [o.start_column, o.end_column] })
  end

  def test_dont_report_with_proper_spaces
    offenses = analyze_theme(
      ThemeCheck::SpaceInsideBraces.new,
      "templates/index.liquid" => <<~END,
        {% assign x = 1 %}
        {{ x }}
        {% form 'type', object, key: value, key2: value %}
        {% endform %}
        {{ "ignore:stuff,  indeed" }}
        {% render 'product-card',
          product_card_product: product_recommendation,
          show_vendor: section.settings.show_vendor,
          media_size: section.settings.product_recommendations_image_ratio,
          center_align_text: section.settings.center_align_text
        %}
            {% render 'product-card',
              product_card_product: product,
              show_vendor: section.settings.show_vendor,
              media_size: section.settings.product_image_ratio,
              center_align_text: section.settings.center_align_text,
              show_full_details: true
            %}
      END
    )
    assert_equal("", offenses.join("\n"))
  end

  def test_corrects_missing_space
    expected_sources = {
      "templates/index.liquid" => <<~END,
        {{ x }}
        {{ x }}
      END
    }
    sources = fix_theme(
      ThemeCheck::SpaceInsideBraces.new,
      "templates/index.liquid" => <<~END,
        {{ x}}
        {{x }}
      END
    )
    sources.each do |path, source|
      assert_equal(source, expected_sources[path])
    end
  end

  def test_corrects_extra_space
    expected_sources = {
      "templates/index.liquid" => <<~END,
        {{ x }}
        {{ x }}
      END
    }
    sources = fix_theme(
      ThemeCheck::SpaceInsideBraces.new,
      "templates/index.liquid" => <<~END,
        {{ x  }}
        {{  x }}
      END
    )
    sources.each do |path, source|
      assert_equal(source, expected_sources[path])
    end
  end
end
