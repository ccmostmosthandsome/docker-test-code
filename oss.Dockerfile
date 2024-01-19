FROM node:14-alpine as builder

ENV ACCESS_KEY_ID LTAI5tE7hukgeFfFx1UejyGP
ENV ACCESS_KEY_SECRET 9SG1MugM8OwrevAe1V2EJuYpe6TI0Q
ARG ENDPOINT
ENV PUBLIC_URL https://docker-test1.oss-cn-beijing.aliyuncs.com/

WORKDIR /code

# 为了更好的缓存，把它放在前边
RUN wget http://gosspublic.alicdn.com/ossutil/1.7.7/ossutil64 -O /usr/local/bin/ossutil 
RUN chmod 755 /usr/local/bin/ossutil 
RUN ossutil config -i ${ACCESS_KEY_ID} -k ${ACCESS_KEY_SECRET} -e $ENDPOINT

# 单独分离 package.json，是为了安装依赖可最大限度利用缓存
ADD package.json yarn.lock /code/
RUN yarn

ADD . /code
RUN npm run build && npm run oss:cli

# 选择更小体积的基础镜像
FROM nginx:alpine
ADD nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder code/build /usr/share/nginx/html
