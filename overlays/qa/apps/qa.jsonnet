function(
  namespace = "argocd",
  name = "qa",
  namePrefix = "",
  nameSuffix = "",
  targetRevision = "qa",
  apiImage = null,
  uiImage = null,
  nginxImage = null,
  authImage = null,
  centralConfigImage = null,
  producerImage = null
)

local params = import '../components/images.json';

(import '../../../base/app.libsonnet') (
  apiImage = if apiImage != null then apiImage else params.apiImage,
  uiImage = if uiImage != null then uiImage else params.uiImage,
  nginxImage = if nginxImage != null then nginxImage else params.nginxImage,
  authImage = if authImage != null then authImage else params.authImage,
  centralConfigImage = if centralConfigImage != null then centralConfigImage else params.centralConfigImage,
  producerImage = if producerImage != null then producerImage else params.producerImage,
  namePrefix = namePrefix, nameSuffix = nameSuffix, namespace = namespace, name = name,
  targetRevision = targetRevision, path = 'overlays/qa'
)
