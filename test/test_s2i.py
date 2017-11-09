#!/usr/bin/python3
import logging
import os

from conu import DockerBackend, S2IDockerImage

import pytest

image_name = os.environ.get("IMAGE_NAME", "ruby")
test_dir = os.path.abspath(os.path.dirname(__file__))
puma_app_path = os.path.join(test_dir, "puma-test-app")
rack_app_path = os.path.join(test_dir, "rack-test-app")


backend = DockerBackend(logging_level=logging.DEBUG)


@pytest.mark.parametrize("app_path", [
    puma_app_path,
    rack_app_path,
])
def test_s2i_extending(app_path):
    i = S2IDockerImage(image_name)
    app_name = os.path.basename(app_path)
    app = i.extend(app_path, app_name)
    try:
        c = app.run_via_binary()
        try:
            c.wait_for_port(8080)
            assert c.is_port_open(8080)
            response = c.http_request("/", port="8080")
            assert response.ok
        finally:
            c.stop()
            c.wait()
            # debugging
            print(c.logs())
            c.delete()
    finally:
        app.rmi()


def test_usage():
    i = S2IDockerImage(image_name)
    c = i.run_via_binary()
    try:
        c.wait()
        logs = c.logs().decode("utf-8").strip()
        usage = i.usage()
        # FIXME: workaround: `docker logs` can't handle logs like these: '\n\n\n'
        assert logs.replace("\n", "") == usage.replace("\n", "")
    finally:
        c.delete()
