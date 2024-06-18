/**
 * @file
 * This file is part of AdGuard Browser Extension (https://github.com/AdguardTeam/AdguardBrowserExtension).
 *
 * AdGuard Browser Extension is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * AdGuard Browser Extension is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AdGuard Browser Extension. If not, see <http://www.gnu.org/licenses/>.
 */

const path = require('path');
const { promises: fsp } = require('fs');
const packageJson = require('../package.json');

const content = `version=${packageJson.version}`;
const FILE_NAME = 'build.txt';

const filePath = path.join('build', FILE_NAME);

/**
 * Writes build.txt file with current version
 *
 * @returns {Promise<void>}
 */
const buildInfo = async () => {
    await fsp.writeFile(filePath, content, 'utf-8');
};

buildInfo();
