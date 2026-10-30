# Global Claude Rules

## Shell commands suggested to the user

When suggesting shell commands for the user to run manually, always chain them as a single block using `&&` and `\` for line breaks. Never use the `!` prefix. Example:

```bash
sudo systemctl restart foo && \
sudo systemctl status foo
```

@RTK.md
