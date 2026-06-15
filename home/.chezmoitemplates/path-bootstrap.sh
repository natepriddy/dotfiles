# Re-establish PATH for tools that run_once_before (install-deps) installed in a
# SEPARATE process, whose exported PATH never reaches these run_onchange scripts
# on a first apply. Plain POSIX sh — no template directives — so it embeds via
# {{ include }} into any consuming script and lints cleanly.
#   - Homebrew: the Apple Silicon (/opt/homebrew) and Linuxbrew (/home/linuxbrew)
#     prefixes are NOT on the default PATH; /usr/local already is.
#   - mise's standalone installer drops its binary in ~/.local/bin.
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "${HOME}/homebrew/bin/brew"; do
  if [ -x "${_brew}" ]; then eval "$("${_brew}" shellenv)"; break; fi
done
unset _brew
case ":${PATH}:" in
  *":${HOME}/.local/bin:"*) ;;
  *) PATH="${HOME}/.local/bin:${PATH}"; export PATH ;;
esac
