function(
  namespace = "hello",
  namePrefix = "qa-",
  nameSuffix = "-simple",
  targetRevision = "qa",
  apiImage = null,
  uiImage = null,
  nginxImage = null
)

local params = import '../params.libsonnet';

(import '../../../base/app.libsonnet') (
  apiImage = if apiImage != null then apiImage else params.apiImage,
  uiImage = if uiImage != null then uiImage else params.uiImage,
  nginxImage = if nginxImage != null then nginxImage else params.nginxImage,
  namePrefix = namePrefix, nameSuffix = nameSuffix, namespace = namespace,
  targetRevision = targetRevision, path = 'overlays/qa/simple'
)
