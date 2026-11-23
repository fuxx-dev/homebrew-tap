class FuxxCompletes < Formula
  desc "Ghost-text suggestions for zsh and bash from your own history"
  homepage "https://github.com/fuxx-dev/fuxx-completes"
  url "https://github.com/fuxx-dev/fuxx-completes/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "abcbd3c3111eca9d8031b2094cb3c01f6d9cdf2b1862adf0bff81a90277c8dad"
  license any_of: ["MIT", "Apache-2.0"]

  depends_on :macos

  # The prebuilt binary from the release's fuxx plugin zip for this Mac's chip (the same bytes
  # fuxx installs); the adapters come from the tagged source above.
  resource "binary" do
    on_arm do
      url "https://github.com/fuxx-dev/fuxx-completes/releases/download/v0.1.0/fuxx-plugin-macos-arm64.zip"
      sha256 "95e831b852072cec58fdb998caf0d06050863fd540685de8b061a2cde3f4dec9"
    end
    on_intel do
      url "https://github.com/fuxx-dev/fuxx-completes/releases/download/v0.1.0/fuxx-plugin-macos-x86_64.zip"
      sha256 "aab9b654ea9a63a6c09ff1fb6f5077218a0711d647387a03fa8c09e300cd1401"
    end
  end

  def install
    resource("binary").stage { bin.install "bin/fuxx-completes" }
    pkgshare.install "adapters/zsh", "adapters/bash", "adapters/fish"
    # The binary's crates' notices travel with it, as in the zips (design §8).
    doc.install "THIRD_PARTY_NOTICES.md"
  end

  def caveats
    <<~EOS
      Nothing is turned on for you. Add the line for your shell:

        zsh, in ~/.zshrc:
          source #{HOMEBREW_PREFIX}/share/fuxx-completes/zsh/fuxx-autosuggestions.plugin.zsh

        bash 4.0+, at the end of ~/.bashrc:
          source #{HOMEBREW_PREFIX}/share/fuxx-completes/bash/fuxx-autosuggestions.bash
        (macOS terminals start bash as a login shell, which reads ~/.bash_profile,
        not ~/.bashrc: make sure ~/.bash_profile sources ~/.bashrc.)

        fish (reports your commands; fish keeps its own suggestions):
          ln -s #{HOMEBREW_PREFIX}/share/fuxx-completes/fish/fuxx-autosuggestions.fish ~/.config/fish/conf.d/

      Then open a new shell. `fuxx-completes doctor` shows what is running.
      Before uninstalling, `fuxx-completes forget` wipes its small context file.
    EOS
  end

  test do
    assert_path_exists doc/"THIRD_PARTY_NOTICES.md"
    assert_match "fuxx-completes #{version}", shell_output("#{bin}/fuxx-completes doctor")
    assert_match "usage: fuxx-completes", shell_output("#{bin}/fuxx-completes nope 2>&1", 2)
    assert_empty shell_output("zsh -fc 'source #{pkgshare}/zsh/fuxx-autosuggestions.plugin.zsh'")
  end
end
