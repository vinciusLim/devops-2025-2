# Stage 1 - Build Stage
FROM node:22-alpine3.20 as build

# Set working directory
WORKDIR /usr/src/app

# Copy package.json and dependency files
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

# Install dependencies
RUN corepack enable && yarn  

# Copy the rest of the application code
COPY . .

# Build the application
RUN yarn prisma generate
RUN yarn build
RUN yarn workspaces focus --production && yarn cache clean


# Stage 2 - Production Stage
FROM node:22-alpine3.20 as production

# Set working directory
WORKDIR /usr/src/app

# Copy only the necessary files from the build stage
COPY --from=build /usr/src/app/package.json ./package.json
COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/prisma ./prisma

# Expose the application port
EXPOSE 3000

# Start the application
CMD ["npm", "run", "start:prod:migrate"]