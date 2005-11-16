
char *
contractPath1(char *path, char *lastSlash)/*{{{*/
{
  char *b, c;
  int len = strlen(path);
  if (!*path) return path;
  if (*path == '/')
  {
    memmove(path, path+1, len);
    return contractPath1(path, lastSlash);
  }
  if (*path == '.' && path[1] == '.' && path[2] == '/')
  {
    if (lastSlash == NULL)
    {
      return NULL;
    }
    memmove(lastSlash, path+2, len - 1);
    return lastSlash+1;
  }
  if (*path == '.' && path[1] == '/')
  {
    memmove(path, path+2, len - 1);
    return contractPath1(path, lastSlash);
  }
  b = path - 1;
  while ((c = *path))
  {
    if (c == '/') 
    {
      b = contractPath1(path+1, b);
      if (b == NULL) return NULL;
      path = b - 1;
    }
    path++;
  }
  return path;
}/*}}}*/

char *
contractPath(char *path)
{
  return contractPath1(path, NULL);
}

struct uoHashEntry
{
  unsigned long hashval;
  char *key;
};

struct parseCtx
{
  char *fileprefix;
  int fpl;
  char *mapprefix;
  int mpl;
  char *root;
  int rl;
  InterpContext *ctx;
  hashtable *uoTable;
  hashtable *smlTable;
  hashtable *ulTable;
};

struct char_charHashEntry
{
  char *key;
  char *val;
  unsigned long hashval;
};

void parsedie(void)
{
  return;
}

enum ParseRV
{
  Parse_OK = 0,
  Parse_ALLOCERROR = 1,
  Parse_DUPLICATE = 4,
  Parse_INTERMALERROR = 6
};

char *
addMlb(char *context, const char *in)/*{{{*/
{
  char c, *p, *ls, *tmp;
  p = context;
  ls = NULL;
  while ((c = *p))
  {
    if (c == '/')
    {
      ls = p;
    }
    p++;
  }
  if (ls == NULL) ls = context;
  tmp = alloca(strlen(ls) + 1);
  if (!tmp) return NULL;
  strcpy(tmp, ls);
  strcpy(ls,in);
  ls += strlen(in);
  strcpy(ls,tmp);
  return ls;
}/*}}}*/

// trashes uo and mlop
char *
formLoc(char *uo, int uoLength, char *fileprefix, int fpl, char *mapprefix, int mpl,/*{{{*/
        char *mlop, int mlopLength, char *root, int rootLength, char *res)
{
  char *tmp;
  if (mlop == NULL)
  {
    if (uo[0] == '/')
    {
      strncpy(res,uo,uoLength);
      res[uoLength] = 0;
      if (strstr(res,fileprefix) == fileprefix)
      {
        tmp = res+fpl;
        strcpy(uo,tmp);
        strcpy(res,mapprefix);
        strcpy(res+mpl, "/");
        strcpy(res+mpl+1, uo);
        return contractPath(res);
      }
      else
      {
        return NULL;
      }
    }
    else
    {
      strncpy(res,uo,uoLength);
      res[uoLength] = 0;
      if (!contractPath(res)) return NULL;
      strncpy(uo,res, uoLength);
      strcpy(res,mapprefix);
      strcpy(res+mpl, "/");
      strncpy(res+mpl+1, uo, uoLength);
      res[mpl+1+uoLength] = 0;
      return contractPath(res);
    }
  }
  else
  {
    if (mlop[0] == '/')
    {
      strncpy(res,mlop,mlopLength);
      res[mlopLength] = 0;
      if (!contractPath(res)) return NULL;
      strncpy(mlop,res,mlopLength);
      strcpy(res,root);
      strncpy(res+rootLength,mlop,mlopLength);
      res[mlopLength+rootLength] = 0;
      return contractPath(res);
    }
    else
    {
      strncpy(res,mlop,mlopLength);
      res[mlopLength] = 0;
      if (!contractPath(res)) return NULL;
      strncpy(mlop,res,mlopLength);
      strcpy(res,mapprefix);
      strcpy(res+mpl,"/");
      strncpy(res+mpl+1,mlop,mlopLength);
      res[mpl+1+mlopLength] = 0;
      return contractPath(res);
    }
  }
}/*}}}*/

const char *mlb = "MLB/SMLserver";

char *
formUoUl(char *uo, int uoLength, char *fileprefix, int fpl, char *res)/*{{{*/
{
  if (uo[0] == '/')
  {
    strncpy(res, uo, uoLength);
    res[uoLength] = 0;
  }
  else
  {
    strcpy(res,fileprefix);
    res[fpl] = '/';
    res[fpl+1] = 0;
    strncpy(res + fpl+1, uo, uoLength);
    res[fpl + 1 + uoLength] = 0;
  }
  return contractPath(res);
}/*}}}*/

char *
formUo(char *uo, int uoLength, char *fileprefix, int fpl, char *res)/*{{{*/
{
  formUoUl(uo,uoLength,fileprefix,fpl,res);
  return addMlb(res,mlb);
}/*}}}*/

char *
formUl(char *ul, int ulLength, char *fileprefix, int fpl, char *res)/*{{{*/
{
  return formUoUl(ul, ulLength, fileprefix, fpl, res);
}/*}}}*/

int
path(char *file)/*{{{*/
{
  int i,ls;
  ls = -1;
  for (i = 0; file[i]; i++)
  {
    if (file[i] == '/') ls = i;
  }
  return ls;
}/*}}}*/

int
toUlHashTable(void *pctx1, char *ul, int ulLength, char *loc, int locLength)/*{{{*/
{
  struct parseCtx *pctx, rpctx;
  struct char_charHashEntry *he, he1;
  char *tmp, *tmp2, *tmp3;
  void **r;
  int i;
  pctx = (struct parseCtx *) pctx1;
  tmp = (char *) alloca(ulLength+1+pctx->fpl);
  tmp2 = (char *) alloca(locLength+1+pctx->mpl);
  if (!tmp || !tmp2) return Parse_ALLOCERROR;
  if (!formUl(ul,ulLength, pctx->fileprefix, pctx->fpl, tmp)) return 2;
  if (!formMap(loc,locLength, pctx->mapprefix, pctx->mpl, tmp2)) return 3;
  he1.key = tmp;
  he1.hashval = charhashfunction(he1.key);
  r = (void **) (&tmp3);
  if (hashfind(&(pctx->ctx->code.ulTable), &he1, r) == hash_DNE)
  {
    he = (struct char_charHashEntry *) malloc(sizeof(struct char_charHashEntry) + strlen(tmp) + 1 +
                                                     strlen(tmp2) + 1);
    if (!he) return Parse_ALLOCERROR;
    he->key = (char *) (he+1);
    he->val = he->key + strlen(tmp) + 1;
    strcpy(he->key, tmp);
    strcpy(he->val, tmp2);
    he->hashval = he1.hashval;
    if (hashupdate(&(pctx->ctx->code.ulTable), he, he->val) != hash_OK) return Parse_ALLOCERROR;
  }
  else
  {
    return 4;
  }
  tmp = (char *) alloca(strlen(he->key) + 1 + strlen(he->val) + 1);
  if (!tmp) return Parse_ALLOCERROR;
  tmp2 = he->key + strlen(he->key) + 1;
  i = path(he->key);
  if (i == -1) return Parse_INTERMALERROR;
  strncpy(tmp, he->key, i+1);
  tmp[i+1] = 0;
  i = path(he->val);
  if (i == -1) return Parse_INTERMALERROR;
  strncpy(tmp2, he->val, i+1);
  tmp[i+1] = 0;

  rpctx.fileprefix = tmp;
  rpctx.fpl = strlen(rpctx.fileprefix);
  rpctx.mapprefix = tmp2;
  rpctx.mpl = strlen(rpctx.mapprefix);
  rpctx.root = pctx->root;
  rpctx.rl = pctx->rl;
  rpctx.ctx = pctx->ctx;
  rpctx.uoTable = pctx->uoTable;
  rpctx.smlTable = pctx->smlTable;
  rpctx.ulTable = pctx->ulTable;
  recurseParse(&rpctx, he->key);
  return Parse_OK;
}/*}}}*/

int 
toSmlHashTable(void *pctx1, char *uo, int uoLength, char *mlop, int mlopLength)/*{{{*/
{
  struct parseCtx *pctx;
  InterpContext *ctx;
  struct char_charHashEntry *he, he1;
  char *tmp, *tmp2, *tmp3;
  pctx = (struct parseCtx *) pctx1;
  ctx = pctx->ctx;
  tmp = (char *) alloca(uoLength + 2 + pctx->fpl + strlen(mlb));
  tmp2 = (char *) alloca(uoLength + 2 + pctx->fpl + mlopLength + pctx->rl + pctx->mpl);
  if (!tmp || !tmp2) return Parse_ALLOCERROR;
  if (!formUo(uo, uoLength, pctx->fileprefix, pctx->fpl, tmp)) return 2;
  if (!formLoc(uo,uoLength, pctx->fileprefix, pctx->fpl, pctx->mapprefix, pctx->mpl,
          mlop, mlopLength, pctx->root, pctx->rl, tmp2)) return 3;
  he1.key = tmp2;
  he1.hashval = charhashfunction(he1.key);
  if (hashfind(&(ctx->code.smlTable), &he1, (void **) &tmp3) == hash_DNE)
  {
    he = (struct char_charHashEntry *) malloc(sizeof (struct char_charHashEntry) +
                                              strlen(tmp) + strlen(tmp2) + 2);
    if (!he) return Parse_ALLOCERROR;
    he->key = (char *)(he+1);
    strcpy(he->key, he1.key);
    he->hashval = he1.hashval;
    he->val = he->key + strlen(he->key) + 1;
    strcpy(he->val,tmp);
    hashupdate(&(ctx->code.smlTable), he, he->val);
  }
  else 
  {
    return Parse_DUPLICATE;
  }
  return Parse_OK;
}/*}}}*/

int
extendInterp (void *pctx1, char *uo, int len)/*{{{*/
{
  struct parseCtx *pctx;
  InterpContext *ctx;
  struct uoHashEntry *he, he1;
  void *r;
  char *tmp;
  pctx = (struct parseCtx *) pctx1;
  ctx = pctx->ctx;
  tmp = (char *) alloca(len+1+pctx->fpl);
  if (!tmp) return Parse_ALLOCERROR;
  if (!formUo(uo, len, pctx->fileprefix, pctx->fpl, tmp)) return 2;
  he1.key = tmp;
  he1.hashval = charhashfunction(tmp);
  if (hashfind(&(ctx->code.uoTable), &he1, &r) == hash_DNE)
  {
    he = (struct uoHashEntry *) malloc(sizeof (struct uoHashEntry) + strlen(tmp) + 1);
    if (!he) return Parse_ALLOCERROR;
    he->key = (char *)(he+1);
    strcpy(he->key, tmp);
    he->hashval = he1.hashval;
    hashupdate(&(ctx->code.uoTable), he, NULL);
//    interpLoadExtend(ctx->interp, tmp);
  } // if already in the interpreter then skip
  return Parse_OK;
}/*}}}*/

