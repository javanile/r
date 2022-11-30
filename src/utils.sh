
rsvm_init_folder_structure()
{
  echo -n "Creating the respective folders for rust $1 ... "

  mkdir -p "$RSVM_DIR/versions/$1/src"
  mkdir -p "$RSVM_DIR/versions/$1/dist"

  echo "done"
}

rsvm_file_download()
{
  local OPTS
  # download custom etag
  if [ "$3" = true ]
  then
    curl -I -s $1 | grep ETag | awk '{print $2}' > $2.etag
    OPTS='-#'
  else
    OPTS='-s'
  fi

  #echo $1 $2

  if [ $(rsvm_check_etag $1 $2) = 0 ]
  then
    # not match etag; new download
    curl $OPTS -o $2 $1
  else
    # match etag; resume download
    curl $OPTS -o $2 -C - $1
  fi

}

rsvm_append_path()
{
  local newpath
  if [[ ":$1:" != *":$2:"* ]];
  then
    newpath="${1:+"$1:"}$2"
  else
    newpath="$1"
  fi
  echo $newpath
}


rsvm_check_etag()
{
  # Check which md5sum to use
  if [ -f "$(which md5sum)" ]; then
      MD5=md5sum
  elif [ -f "$(which md5)" ]; then
      MD5=md5
  else
      echo "md5sum not found!"
      exit 1
  fi

  if [ -f $2.etag ]
  then
    curl -s -I -H "If-None-Match:$(cat $2.etag)" $1 | grep 304 | wc -l
  elif [ -f $2 ]
  then
    local ETAG=$($MD5 $2 | awk '{print $1}')
    curl -s -I -H "If-None-Match:\"$ETAG\"" $1 | grep 304 | wc -l
  else
    echo 0
  fi
}
