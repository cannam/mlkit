#include <stdlib.h>
#include <errno.h>
#include "Syserr.h"

struct syserr_entry src[] = {
  {"EACCES",EACCES},
  {"E2BIG", E2BIG},
  {"EADDRINUSE",EADDRINUSE},
  {"EADDRNOTAVAIL",EADDRNOTAVAIL},
  {"EAFNOSUPPORT",EAFNOSUPPORT},
  {"EAGAIN",EAGAIN},
  {"EALREADY",EALREADY},
  {"EBADF",EBADF},
  {"EBADMSG",EBADMSG},
  {"EBUSY",EBUSY},
  {"ECANCELED",ECANCELED},
  {"ECHILD",ECHILD},
  {"ECONNABORTED",ECONNABORTED},
  {"ECONNREFUSED",ECONNREFUSED},
  {"ECONNRESET",ECONNRESET},
  {"EDEADLK",EDEADLK},
  {"EDESTADDRREQ",EDESTADDRREQ},
  {"EDOM",EDOM},
  {"EDQUOT",EDQUOT},
  {"EEXIST",EEXIST},
  {"EFAULT",EFAULT},
  {"EFBIG",EFBIG},
  {"EHOSTUNREACH",EHOSTUNREACH},
  {"EIDRM",EIDRM},
  {"EILSEQ",EILSEQ},
  {"EINPROGRESS",EINPROGRESS},
  {"EINTR",EINTR},
  {"EINVAL",EINVAL},
  {"EIO",EIO},
  {"EISCONN",EISCONN},
  {"EISDIR",EISDIR},
  {"ELOOP",ELOOP},
  {"EMFILE",EMFILE},
  {"EMLINK",EMLINK},
  {"EMSGSIZE",EMSGSIZE},
  {"EMULTIHOP",EMULTIHOP},
  {"ENAMETOOLONG",ENAMETOOLONG},
  {"ENETDOWN",ENETDOWN},
  {"ENETRESET",ENETRESET},
  {"ENETUNREACH",ENETUNREACH},
  {"ENFILE",ENFILE},
  {"ENOBUFS",ENOBUFS},
  {"ENODATA",ENODATA},
  {"ENODEV",ENODEV},
  {"ENOENT",ENOENT},
  {"ENOEXEC",ENOEXEC},
  {"ENOLCK",ENOLCK},
  {"ENOLINK",ENOLINK},
  {"ENOMEM",ENOMEM},
  {"ENOMSG",ENOMSG},
  {"ENOPROTOOPT",ENOPROTOOPT},
  {"ENOSPC",ENOSPC},
  {"ENOSR",ENOSR},
  {"ENOSTR",ENOSTR},
  {"ENOSYS", ENOSYS},
  {"ENOTCONN",ENOTCONN},
  {"ENOTDIR",ENOTDIR},
  {"ENOTEMPTY",ENOTEMPTY},
  {"ENOTSOCK",ENOTSOCK},
  {"ENOTSUP",ENOTSUP},
  {"ENOTTY",ENOTTY},
  {"ENXIO",ENXIO},
  {"EOPNOTSUPP",EOPNOTSUPP},
  {"EOVERFLOW",EOVERFLOW},
  {"EPIPE",EPIPE},
  {"EPERM",EPERM},
  {"EPROTO",EPROTO},
  {"EPROTONOSUPPORT",EPROTONOSUPPORT},
  {"EPROTOTYPE",EPROTOTYPE},
  {"ERANGE",ERANGE},
  {"EROFS",EROFS},
  {"ESPIPE",ESPIPE},
  {"ESRCH",ESRCH},
  {"ESTALE",ESTALE},
  {"ETIME",ETIME},
  {"ETIMEDOUT",ETIMEDOUT},
  {"ETXTBSY",ETXTBSY},
  {"EWOULDBLOCK",EWOULDBLOCK},
  {"EXDEV",EXDEV},
  {NULL, 1}
};

int 
count(void)
{
  int i = 0;
  while (src[i].name) i++;
  return i;
}

int
cmpName(const struct syserr_entry *k1, const struct syserr_entry *k2)
{
  return strcmp(k1->name, k2->name);
}

int
cmpInt (const struct syserr_entry *k1, const struct syserr_entry *k2)
{
  if (k1->number < k2->number) return -1;
  if (k1->number > k2->number) return 1;
  return 0;
}

int
main(int argc, char**argv)
{
  int j,i;
  j = count();
  printf("static const unsigned int sml_numberofErrors = %d;\n\n", j);
  printf("struct syserr_entry syserrTableName[] = {\n");
  qsort(src, j, sizeof(struct syserr_entry), cmpName);
  i = 0;
  while (i < j)
  {
    printf("  {\"%s\", %s},\n", src[i].name, src[i].name);
    i++;
  }
  printf("  {NULL, -1}\n};\n");

  qsort(src,j,sizeof(struct syserr_entry), cmpInt);
  printf ("struct syserr_entry syserrTableNumber[] = {\n");
  i = 0;
  while (i < j)
  {
    printf("  {\"%s\", %s},\n", src[i].name, src[i].name);
    i++;
  }
  printf("  {NULL, -1}\n};\n");
  return EXIT_SUCCESS;
}
