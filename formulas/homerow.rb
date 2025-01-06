cask "homerow" do
  desc "Keyboard navigation for all of macOS. Click, scroll, and perform tasks with your keyboard."
  homepage "https://www.homerow.app"
  
  version "1.3.0"
  sha256 "bc9996069b624fde72cc3d4b0c9557feb1827621a12a22c806b2424f62f2a10c"

  url "https://builds.homerow.app/v#{version}/Homerow.zip"

  depends_on macos: ">= :monterey"

  uninstall quit: "com.superultra.Homerow"

  app "Homerow.app"

  zap trash: [
    "/System/Volumes/Data/Applications/Homerow.app",
    "~/Library/Application Scripts/com.superultra.HomerowLauncher",
    "~/Library/Application Support/com.superultra.Homerow",
    "~/Library/Caches/com.superultra.Homerow",
    "~/Library/Containers/com.superultra.HomerowLauncher",
    "~/Library/HTTPStorages/com.superultra.Homerow",
    "~/Library/Preferences/com.dexterleng.Homerow.plist",
    "~/Library/Preferences/com.superultra.Homerow.plist",
    "~/Library/Saved Application State/com.superultra.Homerow.savedState",
    "~/Library/WebKit/com.superultra.Homerow",
  ]
end
