# Troubleshooting

## PVC

PVC sometimes won't delete. Run this to ensure it deletes:

```bash
kubectl patch pvc -n immich immich-pvc -p '{"metadata":{"finalizers":null}}'
```

## Immich

On creation of a new database:

```bash
psql
```

```sql
ALTER USER app WITH SUPERUSER;
```
