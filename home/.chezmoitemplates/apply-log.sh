# apply-log.sh — shared logging helpers for chezmoi apply scripts.
# Include with: {{ include ".chezmoitemplates/apply-log.sh" }}
#
# Each script appends one line to $CHEZMOI_APPLY_LOG:
#   PASS|<script>|<message>
#   WARN|<script>|<message>
#   FAIL|<script>|<message>
#
# run_onchange_after_99-summary.sh reads the log and prints a report.
# The log lives in $TMPDIR so it is per-session and never persists across reboots.

CHEZMOI_APPLY_LOG="${TMPDIR:-/tmp}/chezmoi-apply-$(id -u).log"

# log_pass <script> <message>
log_pass() { echo "PASS|$1|$2" >> "${CHEZMOI_APPLY_LOG}"; }

# log_warn <script> <message>
log_warn() { echo "WARN|$1|$2" >> "${CHEZMOI_APPLY_LOG}"; }

# log_fail <script> <message>
log_fail() { echo "FAIL|$1|$2" >> "${CHEZMOI_APPLY_LOG}"; }
