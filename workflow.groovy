node {
	git 'https://github.com/pjestrada/todobackend.git'

	try{
		stage 'Run unit/integration tests'
		sh 'make test'

		stage 'Build artifacts'
		sh 'make build'

		stage 'Create release environment'
		sh 'make release'

		stage 'Tag and publish release image'

		sh "make tag latest \$(git rev-parse --short HEAD) \$(git tag --points-at HEAD)"
		sh "make buildtag master \$(git tag --points-at HEAD)"

		withEnv(["DOCKER_USER=${DOCKER_USER}", "DOCKER_PASSWORD=${DOCKER_PASSWORD}"]){
			sh 'make login'
		}


	}
	finally{
		stage 'Collect test reports'
		step([$class: 'JUnitResultArchiver', testResults: '**/reports/*.xml'])
		stage 'Clean up'
		sh 'make clean'
		sh 'make logout'
	}
}