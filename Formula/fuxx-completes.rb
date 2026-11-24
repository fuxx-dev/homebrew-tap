class FuxxCompletes < Formula
  desc "Ghost-text suggestions for zsh and bash from your own history"
  homepage "https://github.com/fuxx-dev/fuxx-completes"
  url "https://github.com/fuxx-dev/fuxx-completes/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "3f075cf0097891a736d179fee22a162b659de486a7bc67f89d3e9c768bc17eab"
  license any_of: ["MIT", "Apache-2.0"]

  depends_on :macos

  # The prebuilt binary from the release's fuxx plugin zip for this Mac's chip (the same bytes
  # fuxx installs); the adapters come from the tagged source above.
  resource "binary" do
    on_arm do
      url "https://github.com/fuxx-dev/fuxx-completes/releases/download/v0.1.1/fuxx-plugin-macos-arm64.zip"
      sha256 "66eddb48f45f0d7f3fe152dcd4755ae6cf87451be11967babadf4c44b8b696be"
    end
    on_intel do
      url "https://github.com/fuxx-dev/fuxx-completes/releases/download/v0.1.1/fuxx-plugin-macos-x86_64.zip"
      sha256 "a6f7f3819ea023af0645168fa145dde509b700ff4717e0bb9bf8e5c9ce5e2ab0"
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
