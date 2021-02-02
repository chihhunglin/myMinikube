#!/usr/bin/env bash
SOURCE_HUB=istio
#DEST_HUB=my-registry # Replace this with the destination hub
DEST_HUB=core.harbor.domain/devops/istio
#IMAGES=( install-cni operator pilot proxyv2 )
IMAGES=( operator pilot proxyv2 )
VERSIONS=( 1.8.1 ) # Versions to copy
#VARIANTS=( "" "-distroless" ) # Variants to copy
for image in install-cni operator pilot proxyv2
do
	for version in $VERSIONS
	do
		#for variant in $VARIANTS; do
		#name=$image:$version$variant
		name=$image:$version
		docker pull $SOURCE_HUB/$name
		docker tag $SOURCE_HUB/$name $DEST_HUB/$name
		docker push $DEST_HUB/$name
		docker rmi $SOURCE_HUB/$name
		docker rmi $DEST_HUB/$name
	done
done
#done

