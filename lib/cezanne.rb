require "cezanne/version"
require "cezanne/local_files"
require "cezanne/remote_files"
require "cezanne/image"
require "cezanne/comparison"

module Cezanne

  def check_visual_regression_for page_name, opts = {}
    screenshot = take_screenshot page_name, opts
    reference_screenshot = get_reference_screenshot_for page_name

    unless reference_screenshot
      mark_as_new screenshot
      raise "new screenshot for #{page_name}"
    end

    if spot_differences_between screenshot, reference_screenshot
      mark_for_review screenshot
      raise "screenshot for #{page_name} didn't match"
    end

    return true
  end

  private

    def take_screenshot page_name, opts
      path = File.join( local_files.path_for(:tmp), file_name_for(page_name) )
      page.driver.browser.save_screenshot(path)
      image(path, opts)
    end


    def get_reference_screenshot_for page_name
      path = File.join( local_files.path_for(:ref), file_name_for(page_name) )
      return false unless File.exists? path
      image(path)
    end

    def file_name_for page_name
      browser_name = page.driver.browser.capabilities.browser_name.gsub(/\s+/, "_")
      browser_version = page.driver.browser.capabilities.version.gsub(/\./, "_")
      "#{page_name}_#{browser_name}_#{browser_version}.gif"
    end

    def mark_as_new screenshot
      FileUtils.mv(screenshot.path, local_files.path_for(:new))
    end

    def mark_for_review screenshot
      FileUtils.mv(screenshot.path, local_files.path_for(:diff))
    end
   
    def image path, opts = {} 
      Cezanne::Image.new(path, opts)
    end
end
