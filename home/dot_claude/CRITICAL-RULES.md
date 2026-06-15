# CRITICAL SYSTEM RULES FOR CLAUDE CODE

## Shell Management - CRASH PREVENTION

**NEVER execute the following pattern - it causes Claude Code to crash with EBADF errors:**

### Prohibited Pattern:
1. Killing a shell process (using KillShell)
2. Immediately running a new Bash command
3. Especially with complex piped docker-compose commands

### Specific Command That Causes Crashes:
```bash
docker-compose logs order-api --tail=100 2>&1 | grep -i -A5 -B5 "error\|exception\|failed\|finalize" | tail -50
```

**Error Pattern:**
```
Error: spawn EBADF
    at ChildProcess.spawn (node:internal/child_process:421:11)
```

## Safe Practices:

1. **Wait for Shell Cleanup**: After killing a shell, wait before issuing new Bash commands
2. **Simplify Docker Commands**: Use simpler docker commands without complex pipes
3. **Prefer Direct Docker**: Use `docker logs <container-id>` over `docker-compose logs` for filtering
4. **Avoid Background Mode**: Don't use `run_in_background` for commands with complex pipes that might hang
5. **One Shell Operation at a Time**: Never rapidly cycle through shell kill/restart operations

## When Working with Docker Logs:

**Instead of:**
```bash
docker-compose logs order-api --tail=100 2>&1 | grep -i -A5 -B5 "error\|exception\|failed\|finalize" | tail -50
```

**Use:**
```bash
# Option 1: Simple docker-compose logs
docker-compose logs order-api --tail=50

# Option 2: Get container ID first, then use docker logs
docker ps --filter "name=order-api" --format "{{.ID}}"
docker logs <container-id> --tail=50

# Option 3: Read logs to file first, then process
docker-compose logs order-api --tail=100 > /tmp/logs.txt
grep -i "error\|exception" /tmp/logs.txt
```

---
**Last Updated:** 2025-10-21
**Reason:** Documented crash pattern caused by rapid shell kill/restart cycles with complex piped commands
