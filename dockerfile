FROM openjdk:17
WORKDIR /app
COPY springboot_ui_cicd.jar /app
EXPOSE 8088
CMD ["java", "-jar", "springboot_ui_cicd.jar"]