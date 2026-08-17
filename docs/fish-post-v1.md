# Post-v1: Fish parity

Fish support is deliberately outside the Zsh v1 release gate. A follow-up
tracking issue should define the intended Fish functions, implement the
thin adapter onto the same daemon protocol, add real Fish integration tests,
and run the same config, completion, history, lifecycle, and migration matrix.
No v1 test result should imply Fish support until that issue is filed
and completed.
