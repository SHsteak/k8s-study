#! /bin/bash

if [ -z "$1" ];then
	echo "$(tput setaf 1)Enter parameters$(tput sgr 0)"

else
	# set
	if [ "$1" = "set" ];then
		echo ''
		echo ''
		# <docker images>:<tag>
		if [ "$2" = "imageName" ];then
			sed -i "s@choshsh/spring-petclinic-data-jdbc:latest@$3@g" "$PWD"/app/app-build.sh
			sed -i "s@choshsh/spring-petclinic-data-jdbc:latest@$3@g" "$PWD"/app/app-build-here.sh
			sed -i "s@choshsh/spring-petclinic-data-jdbc:latest@$3@g" "$PWD"/k8s/was/was-deployment.yaml
			echo "# File: "$PWD"/app/app-build.sh"
			cat "$PWD/app/app-build.sh" | grep $3

			echo ''
			echo "# File: $PWD/k8s/was/was-deployment.yaml"
			cat "$PWD"/k8s/was/was-deployment.yaml | grep $3


		# set <ingress host>
                elif [ "$2" = "ingressDomain" ];then
			sed -i "s@www.choshsh.com@$3@g" "$PWD"/k8s/web/nginx-ingress.yaml
			echo "# File: "$PWD"/k8s/web/nginx-ingress.yaml"
			cat "$PWD"/k8s/web/nginx-ingress.yaml | grep $3

		# set <nfs server> <path>
                elif [ "$2" = "pvNfs" ];then
			sed -i "s@192.168.220.130@$3@g" "$PWD"/k8s/storage/mysql-pv.yaml
			sed -i "s@/Data/mysql@$4@g" "$PWD"/k8s/storage/mysql-pv.yaml
			echo ""$PWD"/k8s/storage/mysql-pv.yaml"
			cat "$PWD"/k8s/storage/mysql-pv.yaml | grep $3
			cat "$PWD"/k8s/storage/mysql-pv.yaml | grep $4
		else
			echo "$(tput setaf 1)Enter parameters.set <param> $(tput sgr 0)"
		fi
		echo ''
		echo ''

	# build jar	
	elif [ "$1" = "build" ];then
		echo ''
		echo ''
		chmod 777 "$PWD"/app/app-build.sh
		"$PWD"/app/app-build.sh
	
	# controll k8s
	elif [ "$1" = "k" ];then

		# pv
		if [ "$2" = "pv" ];then
			if [ "$3" = "del" ];then
                                kubectl delete -f "$PWD"/k8s/storage/mysql-pv.yaml
			else
	                        kubectl apply -f "$PWD"/k8s/storage/mysql-pv.yaml
        	                echo ''
                	        kubectl get pv mysql-pv
                        	echo ''
                        fi

		# pvc
                elif [ "$2" = "pvc" ];then
                        if [ "$3" = "del" ];then
                                kubectl delete -f "$PWD"/k8s/storage/mysql-pvc.yaml
                        else
	                       	kubectl apply -f "$PWD"/k8s/storage/mysql-pvc.yaml
				echo ''
	                        kubectl get pvc mysql-pv-claim
				echo ''
			fi

		# db
                elif [ "$2" = "db" ];then
                        if [ "$3" = "del" ];then
                                kubectl delete -k "$PWD"/k8s/db/
                        else
	                        kubectl apply -k "$PWD"/k8s/db/		
				echo ''
	                        kubectl get svc mysql
				echo ''
				kubectl get deployments.apps mysql --watch
				echo ''
			fi

		# was
                elif [ "$2" = "was" ];then
                        if [ "$3" = "del" ];then
                                kubectl delete -f "$PWD"/k8s/was/was-deployment.yaml
			elif [ "$3" = "scale" ];then
				kubectl scale --replicas=$4 deployment was-deployment
				kubectl get deployment was-deployment --watch
                        else
	                        kubectl apply -f "$PWD"/k8s/was/was-deployment.yaml
				echo ''
	                        kubectl get svc was-service
				echo ''
				kubectl get deployments.apps was-deployment
				echo ''
				kubectl get po --watch
			fi

		# web
		elif [ "$2" = "web" ];then
                        if [ "$3" = "del" ];then
                                kubectl delete -f "$PWD"/k8s/web/
                        else				
				kubectl apply -f "$PWD"/k8s/web/
				echo ''
				kubectl get svc ingress-nginx
				echo ''
				kubectl get ingress minimal-ingress
				echo ''
				kubectl get deployments.apps nginx-ingress-controller --watch
				echo ''
			fi

		# check
                elif [ "$2" = "check" ];then
			echo ''
			curl -Is $3
			echo ''
		
		# reset
		elif [ "$2" = "reset" ];then
			kubectl delete -f "$PWD"/k8s/web/
			kubectl delete -f "$PWD"/k8s/was/was-deployment.yaml
			kubectl delete -k "$PWD"/k8s/db/
			kubectl delete -f "$PWD"/k8s/storage/mysql-pvc.yaml
			kubectl delete -f "$PWD"/k8s/storage/mysql-pv.yaml			
                fi
	fi
fi

exit 0
